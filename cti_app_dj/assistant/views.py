from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.conf import settings
import json
import httpx
import psycopg2
import logging
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
    """Fonction avec reprise automatique pour l'appel API Groq"""
    payload = {
        "model": "mixtral-8x7b-32768",
        "messages": [
            {
                "role": "system",
                "content": """Tu es un expert SQL PostgreSQL. Génère UNIQUEMENT:
                1. Du code SQL valide sans commentaires
                2. Que des requêtes SELECT (pas de modifications de données)
                3. Des requêtes compatibles avec PostgreSQL 14+"""
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

def execute_sql_query(sql_query):
    """Exécute une requête SQL et retourne les résultats"""
    try:
        with psycopg2.connect(**DB_CONFIG) as conn:
            with conn.cursor() as cur:
                # Validation basique de la requête
                if not sql_query.strip().lower().startswith('select'):
                    raise ValueError("Seules les requêtes SELECT sont autorisées")
                
                cur.execute(sql_query)
                columns = [desc[0] for desc in cur.description]
                rows = cur.fetchall()
                
                return {
                    'columns': columns,
                    'rows': rows,
                    'query': sql_query
                }
    except Exception as e:
        logger.error(f"Erreur SQL: {str(e)} - Requête: {sql_query}")
        raise

@csrf_exempt
async def ask_ai(request):
    if request.method != 'POST':
        return JsonResponse(
            {"error": "Méthode non autorisée"}, 
            status=405
        )

    try:
        # 1. Vérification des données d'entrée
        try:
            data = json.loads(request.body)
            user_question = data.get('question', '').strip()
            if not user_question:
                return JsonResponse(
                    {"error": "Le champ 'question' est requis"},
                    status=400
                )
        except json.JSONDecodeError:
            return JsonResponse(
                {"error": "Données JSON invalides"},
                status=400
            )

        # 2. Appel à l'API Groq
        async with httpx.AsyncClient() as client:
            try:
                response = await call_groq_api(client, user_question)
                result = response.json()
                sql_query = result['choices'][0]['message']['content']
                
                logger.info(f"Requête générée: {sql_query}")
                
                # 3. Exécution de la requête SQL
                try:
                    query_result = execute_sql_query(sql_query)
                    return JsonResponse({
                        "success": True,
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
                        "error": f"Erreur base de données: {str(e)}",
                        "generated_sql": sql_query
                    }, status=500)

            except httpx.HTTPStatusError as e:
                logger.error(f"Erreur API Groq: {str(e)}")
                return JsonResponse({
                    "success": False,
                    "error": f"Erreur API: {e.response.text}",
                    "status_code": e.response.status_code
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