from django.shortcuts import render, redirect, get_object_or_404
from .models import List, Word 

from rest_framework.decorators import api_view
from rest_framework.response import Response
from .serializers import ListSerializer, WordSerializer

@api_view(['GET'])
def listeler_api(request):
    listeler = List.objects.all()
    serializer = ListSerializer(listeler, many=True)
    return Response(serializer.data)

@api_view(['GET'])
def kelimeler_api(request, liste_id):
    kelimeler = Word.objects.filter(liste_id=liste_id)
    serializer = WordSerializer(kelimeler, many=True)
    return Response(serializer.data)

def ana_sayfa(request):
    listeler = List.objects.all()
    return render(request, 'index.html', {'listeler': listeler})

def liste_detay(request, liste_id):
  
    secilen_liste = get_object_or_404(List, id=liste_id)
    
    kelimeler = Word.objects.filter(liste=secilen_liste)
    
    return render(request, 'liste_detay.html', {'liste': secilen_liste, 'kelimeler': kelimeler})

def durum_degistir(request, kelime_id):
    kelime = get_object_or_404(Word, id=kelime_id)
    
    if kelime.is_learned:
        kelime.is_learned = False
    else:
        kelime.is_learned = True
        
    kelime.save()
    return redirect('liste_detay', kelime.liste.id)

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from .models import Word 

@csrf_exempt
def kelime_guncelle(request, pk):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            kelime = Word.objects.get(pk=pk)
            kelime.is_learned = data.get('is_learned', False)
            kelime.save()
            return JsonResponse({'status': 'success', 'message': 'Kelime güncellendi'}, status=200)
        except Word.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Kelime bulunamadı'}, status=404)
    return JsonResponse({'status': 'error', 'message': 'Sadece POST isteği atılabilir'}, status=400)