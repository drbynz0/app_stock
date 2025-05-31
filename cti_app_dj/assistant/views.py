from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
import httpx  # Alternative moderne à requests
import psycopg2
import asyncio

@csrf_exempt
async def ask_ai(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        user_question = data.get('question')

        # Configuration Groq API
        GROQ_API_KEY = "votre_cle_api_groq"
        GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
        
        async with httpx.AsyncClient() as client:
            # 1. Appel à l'API Groq
            try:
                response = await client.post(
                    GROQ_URL,
                    headers={
                        'Authorization': f'Bearer {GROQ_API_KEY}',
                        'Content-Type': 'application/json'
                    },
                    json={
                        "model": "mixtral-8x7b-32768",
                        "messages": [
                            {
                                "role": "system", 
                                "content": "Tu es un expert SQL. Génère UNIQUEMENT du code PostgreSQL valide sans commentaires."
                            },
                            {"role": "user", "content": user_question}
                        ],
                        "temperature": 0.3
                    },
                    timeout=30.0
                )
                
                response.raise_for_status()
                sql_query = response.json()['choices'][0]['message']['content']

                # 2. Exécution PostgreSQL
                try:
                    conn = psycopg2.connect(
                        dbname="cti_app_db", 
                        user="postgres", 
                        password="votre_mdp",
                        host="localhost"
                    )
                    with conn.cursor() as cur:
                        cur.execute(sql_query)
                        result = cur.fetchall()
                    
                    return JsonResponse({
                        "success": True,
                        "result": result,
                        "generated_sql": sql_query  # Pour le débogage
                    })
                    
                except Exception as db_error:
                    return JsonResponse({
                        "success": False,
                        "error": f"Database error: {str(db_error)}",
                        "generated_sql": sql_query
                    }, status=500)

            except httpx.HTTPError as api_error:
                return JsonResponse({
                    "success": False,
                    "error": f"API error: {str(api_error)}"
                }, status=502)