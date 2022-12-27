from django.shortcuts import render
from django.http import HttpResponse

# Create your views here - serves HTTP requests


def index(response):
    return HttpResponse("<h1>hi from Thea</h1>")


def differentView(response):
    return HttpResponse("<h1>bye from Thea</h1>")
