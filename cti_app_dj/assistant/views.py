from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.conf import settings
import json
import httpx
import psycopg2
import logging
import re
from tenacity import retry, stop_after_attempt, wait_exponential

logger = logging.getLogger(__name__)

# Configuration de la base de données
DB_CONFIG = {
    'dbname': settings.DATABASES['default']['NAME'],
    'user': settings.DATABASES['default']['USER'],
    'password': settings.DATABASES['default']['PASSWORD'],
    'host': settings.DATABASES['default']['HOST'],
    'port': settings.DATABASES['default']['PORT']
}

@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=2, max=10))
async def call_groq_api(client, question):
    """Appelle l'API Groq avec un prompt orienté gestion commerciale"""
    payload = {
        "model": "llama3-70b-8192",
        "messages": [
            {
                "role": "system",
                "content": (
                    "Tu es CTI Assistant spécialiste en gestion commerciale, ventes, gestion de stock et et expert en language SQL."
                    "L'utilisateur est un gérant d'une entreprise de vente des articles d'informatique comme PC, ordinateur Souris, routeur, Imprimente, etc. (CTI TECHNOLOGIE)"
                    " Toi tu es là pour lui aider à lui donner des iNformations direct liées à sa base de donnée PostgreSQL avec des réponses bien reformulé."
                    "Tu doit accépter seulement tout les requetes SELECT."
                    "C'est à toi d'executer les requetes et donner les résultats de la requete en langage naturelle"
                    "Il peut aussi te demander des informations sur lui même, sur son entreprise et sur leurs employés."
                    "Tu peux aussi lui donner des suggestions liée à la gestion de stock, la vente, la gestion de la base de donnée, etc."
                    "Lui indiquer si il y a des données incompatibles dans la base de donnée, etc."
                    " Tu peux aussi répondre à des questions générales, proposer des conseils pour améliorer une application de gestion,"
                    " aider à l’analyse des performances commerciales et stock, et expliquer clairement les résultats."
                    " N’utilise pas de commentaires SQL et évite toute requête destructive."
                )
            },
            {"role": "user", "content": question}
        ],
        "temperature": 0.3,
        "max_tokens": 1000
    }

    response = await client.post(
        settings.GROQ_API_URL,
        headers={
            'Authorization': f'Bearer {settings.GROQ_API_KEY}',
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        },
        json=payload,
        timeout=30.0
    )
    response.raise_for_status()
    return response

def extract_sql_and_comment(content):
    """Tente d'extraire la requête SQL et la reformulation"""
    sql_match = re.search(r"```sql\\n(.*?)```", content, re.DOTALL)
    sql = sql_match.group(1).strip() if sql_match else None
    explanation = re.split(r"```sql.*?```", content, flags=re.DOTALL)[0].strip()
    return explanation, sql

def execute_sql_query(sql_query):
    try:
        with psycopg2.connect(**DB_CONFIG) as conn:
            with conn.cursor() as cur:
                if not sql_query.strip().lower().startswith('select'):
                    raise ValueError("Seules les requêtes SELECT sont autorisées")
                cur.execute(sql_query)
                columns = [desc[0] for desc in cur.description]
                rows = cur.fetchall()
                return {'columns': columns, 'rows': rows, 'query': sql_query}
    except Exception as e:
        logger.error(f"Erreur SQL: {str(e)} - Requête: {sql_query}")
        raise

@csrf_exempt
async def ask_ai(request):
    if request.method != 'POST':
        return JsonResponse({"error": "Méthode non autorisée"}, status=405)

    try:
        data = json.loads(request.body)
        user_question = data.get('question', '').strip()
        if not user_question:
            return JsonResponse({"error": "Le champ 'question' est requis"}, status=400)
    except json.JSONDecodeError:
        return JsonResponse({"error": "Données JSON invalides"}, status=400)

    async with httpx.AsyncClient() as client:
        try:
            response = await call_groq_api(client, user_question)
            result = response.json()
            content = result['choices'][0]['message']['content']
            explanation, sql_query = extract_sql_and_comment(content)

            # Si requête SQL valide : exécution
            if sql_query:
                try:
                    query_result = execute_sql_query(sql_query)
                    return JsonResponse({
                        "success": True,
                        "human_response": explanation,
                        "data": query_result['rows'],
                        "columns": query_result['columns'],
                        "generated_sql": query_result['query']
                    })
                except ValueError as e:
                    return JsonResponse({"success": False, "error": str(e), "generated_sql": sql_query}, status=400)
                except Exception as e:
                    return JsonResponse({"success": False, "error": str(e), "generated_sql": sql_query}, status=500)
            else:
                # Pas de SQL : simple réponse explicative
                return JsonResponse({"success": True, "human_response": explanation})

        except httpx.HTTPStatusError as e:
            logger.error(f"Erreur API Groq: {str(e)}")
            return JsonResponse({"success": False, "error": f"Erreur API: {e.response.text}"}, status=502)
        except httpx.RequestError as e:
            logger.error(f"Erreur réseau: {str(e)}")
            return JsonResponse({"success": False, "error": "Erreur de connexion à l'API"}, status=503)
        except Exception as e:
            logger.exception("Erreur inattendue:")
            return JsonResponse({"success": False, "error": "Erreur interne du serveur"}, status=500)
