from django.http import HttpResponse
from django.shortcuts import render

from .models import Item, ToDoList

# Create your views here - serves HTTP requests


def index(response, id):
    ls = ToDoList.objects.get(id=id)
    item = ls.item_set.get(id=1)
    return HttpResponse("<h1>%s</h1><br></br> <p>%s</p>" % (ls.name, str(item.text)))
