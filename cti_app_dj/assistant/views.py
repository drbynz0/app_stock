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
        "model": "gemma2-9b-it",
        "messages": [
            {
                "role": "system",
                "content": (
                    "Tu es CTI Assistant, expert en gestion commerciale, ventes, gestion de stock et langage SQL. "
                    "L'utilisateur est le gérant de CTI TECHNOLOGIE, une entreprise vendant des articles informatiques comme des PC, souris, routeurs, imprimantes, etc. "
                    "Tu es là pour l’aider à interroger sa base de données PostgreSQL via des requêtes SELECT uniquement, et à lui fournir les résultats en langage naturel. "
                    "Tu peux également lui donner des conseils sur la gestion des stocks, l'amélioration de son application, détecter des données incohérentes dans la base, et analyser ses performances commerciales. "
                    "Ne réponds qu’aux requêtes SELECT, sans utiliser de commentaires SQL ni de requêtes destructives."
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
    sql_match = re.search(r"```sql\s+(.*?)\s*```", content, re.DOTALL)
    sql = sql_match.group(1).strip() if sql_match else None
    explanation = re.split(r"```sql.*?```", content, flags=re.DOTALL)[0].strip()
    return explanation, sql

def execute_sql_query(sql_query):
    MAX_ROWS = 50  # Limite de lignes pour éviter surcharge
    dangerous_keywords = ['delete', 'update', 'insert', 'drop', 'alter']

    try:
        # Vérifie que c'est bien une requête SELECT uniquement
        if not sql_query.strip().lower().startswith('select'):
            raise ValueError("Seules les requêtes SELECT sont autorisées")
        if any(keyword in sql_query.lower() for keyword in dangerous_keywords):
            raise ValueError("Requête contenant un mot-clé non autorisé")

        with psycopg2.connect(**DB_CONFIG) as conn:
            with conn.cursor() as cur:
                cur.execute(sql_query)
                columns = [desc[0] for desc in cur.description]
                rows = cur.fetchmany(MAX_ROWS)
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
            logger.info(f"Question utilisateur : {user_question}")
            response = await call_groq_api(client, user_question)
            result = await response.json()
            content = result['choices'][0]['message']['content']
            logger.info(f"Réponse Groq : {content}")

            explanation, sql_query = extract_sql_and_comment(content)

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
                    return JsonResponse({
                        "success": False,
                        "error": str(e),
                        "generated_sql": sql_query
                    }, status=400)
                except Exception as e:
                    return JsonResponse({
                        "success": False,
                        "error": str(e),
                        "generated_sql": sql_query
                    }, status=500)
            else:
                return JsonResponse({
                    "success": True,
                    "human_response": explanation
                })

        except httpx.HTTPStatusError as e:
            logger.error(f"Erreur API Groq: {str(e)}")
            return JsonResponse({
                "success": False,
                "error": f"Erreur API: {e.response.text}"
            }, status=502)
        except httpx.RequestError as e:
            logger.error(f"Erreur réseau: {str(e)}")
            return JsonResponse({
                "success": False,
                "error": "Erreur de connexion à l'API"
            }, status=503)
        except Exception as e:
            logger.exception("Erreur inattendue:")
            return JsonResponse({
                "success": False,
                "error": "Erreur interne du serveur"
            }, status=500)
