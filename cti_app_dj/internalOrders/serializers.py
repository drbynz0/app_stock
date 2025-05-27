from internalOrders.models import InternalOrder, OrderItem
from rest_framework import serializers # type: ignore


class OrderItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderItem
        fields = ['id', 'product', 'product_ref', 'product_name', 'product_image', 'quantity', 'price']

class InternalOrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True)

    class Meta:
        model = InternalOrder
        fields = [
            'id', 'order_num', 'client_id', 'client_name', 'type', 'date',
            'payment_method', 'total_price', 'total_paid', 'remaining_price',
            'status', 'description', 'items', 'created_at', 'updated_at'
        ]

    def create(self, validated_data):
        items_data = validated_data.pop('items')
        order = InternalOrder.objects.create(**validated_data)
        for item_data in items_data:
            OrderItem.objects.create(order=order, **item_data)
        return order
    
    def update(self, instance, validated_data):
        items_data = validated_data.pop('items', None)

        # Mettre à jour les champs de l'InternalOrder
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        if items_data is not None:
            # Supprimer les anciens items liés à cette commande
            instance.items.all().delete()

            # Créer les nouveaux items
            for item_data in items_data:
                OrderItem.objects.create(order=instance, **item_data)

        return instance