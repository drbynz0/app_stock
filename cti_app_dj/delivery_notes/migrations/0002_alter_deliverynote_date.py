# Generated by Django 5.2 on 2025-05-26 09:23

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('delivery_notes', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='deliverynote',
            name='date',
            field=models.DateTimeField(),
        ),
    ]
