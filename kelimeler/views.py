from django.shortcuts import render, redirect, get_object_or_404
from .models import List, Word 

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