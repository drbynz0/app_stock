from rest_framework import generics # type: ignore
from .models import InternalOrder
from .serializers import InternalOrderSerializer

class InternalOrderListCreateView(generics.ListCreateAPIView):
    queryset = InternalOrder.objects.all().order_by('-created_at')
    serializer_class = InternalOrderSerializer

class InternalOrderDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = InternalOrder.objects.all()
    serializer_class = InternalOrderSerializer