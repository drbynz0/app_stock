from django.urls import path # type: ignore
from .views import InternalOrderListCreateView, InternalOrderDetailView

urlpatterns = [
    path('', InternalOrderListCreateView.as_view(), name='internalorder-list-create'),
    path('<int:pk>/', InternalOrderDetailView.as_view(), name='internalorder-detail'),
]