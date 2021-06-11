from django.urls import path
from django.views.decorators.csrf import csrf_exempt
from . import views

urlpatterns = [
    path("", views.index, name="index"),
    path("login", csrf_exempt(views.login), name="login"),
    path("logout", csrf_exempt(views.logout), name="logout"),
    path("upload", csrf_exempt(views.upload), name="upload"),
    path("file/<str:id>", csrf_exempt(views.file), name="file"),
]
