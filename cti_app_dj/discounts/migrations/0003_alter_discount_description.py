# Generated by Django 5.2 on 2025-05-23 11:34

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('discounts', '0002_alter_discount_product_category'),
    ]

    operations = [
        migrations.AlterField(
            model_name='discount',
            name='description',
            field=models.TextField(blank=True, null=True),
        ),
    ]
