from django.urls import path # type: ignore
from .views import request_reset_code, verify_code, reset_password

urlpatterns = [
    path('password_reset/', request_reset_code, name='password_reset'),
    path('password_reset/verify/', verify_code, name='verify_code'),
    path('password_reset/save/', reset_password, name='reset_password'),
]