"""
URL configuration for config project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/6.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from kelimeler import views
from kelimeler import views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', views.ana_sayfa, name='ana_sayfa'),
    path('liste/<int:liste_id>/', views.liste_detay, name='liste_detay'),
    path('durum-degistir/<int:kelime_id>/', views.durum_degistir, name='durum_degistir'),
    
    path('api/listeler/', views.listeler_api, name='listeler_api'),
    path('api/kelimeler/<int:liste_id>/', views.kelimeler_api, name='kelimeler_api'),
    path('api/kelime-guncelle/<int:pk>/', views.kelime_guncelle, name='kelime_guncelle'),
]