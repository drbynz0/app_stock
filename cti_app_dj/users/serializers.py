from rest_framework import serializers  # type: ignore
from django.contrib.auth import authenticate, get_user_model  # type: ignore
from .models import SellerPrivileges

User = get_user_model()


class SellerPrivilegesSerializer(serializers.ModelSerializer):
    class Meta:
        model = SellerPrivileges
        fields = [
            'add_product', 'edit_product', 'delete_product',
            'add_order', 'edit_order', 'delete_order',
            'add_client', 'edit_client', 'delete_client'
        ]


class UserSerializer(serializers.ModelSerializer):
    privileges = SellerPrivilegesSerializer(read_only=True)

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'user_type', 'phone', 'privileges']


class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField()

    def validate(self, data):
        user = authenticate(**data)
        if user and user.is_active:
            return user
        raise serializers.ValidationError("Identifiants incorrects")


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    privileges = SellerPrivilegesSerializer(required=False)

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'password', 'user_type', 'phone', 'privileges']
        extra_kwargs = {
            'password': {'write_only': True}
        }

    def create(self, validated_data):
        privileges_data = validated_data.pop('privileges', None)

        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password'],
            user_type=validated_data.get('user_type', ''),
            phone=validated_data.get('phone', '')
        )

        if user.user_type == 'SELLER':
            SellerPrivileges.objects.create(
                user=user,
                **(privileges_data or {})
            )

        return user

    def update(self, instance, validated_data):
        privileges_data = validated_data.pop('privileges', None)

        for attr, value in validated_data.items():
            if attr == 'password':
                instance.set_password(value)
            else:
                setattr(instance, attr, value)
        instance.save()

        if instance.user_type == 'SELLER' and privileges_data:
            try:
                privileges = SellerPrivileges.objects.get(user=instance)
                for attr, value in privileges_data.items():
                    setattr(privileges, attr, value)
                privileges.save()
            except SellerPrivileges.DoesNotExist:
                SellerPrivileges.objects.create(user=instance, **privileges_data)

        return instance

