from django.db import models

class List(models.Model):
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name

class Word(models.Model):
    liste = models.ForeignKey(List, on_delete=models.CASCADE)
    eng = models.CharField(max_length=100)
    tr = models.CharField(max_length=100)
    example = models.TextField()
    
    is_learned = models.BooleanField(default=False)

    def __str__(self):
        return self.eng