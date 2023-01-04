from django.test import TestCase

from .models import Item, ToDoList

# Create your tests here.

class ToDoListTest(TestCase):
    def setUp(self):
        testlist = ToDoList.objects.get(name="test")
        self.assertEqual(testlist.name, "test")
        
class ItemTest(TestCase):
    def setUp(self):
        todolist = ToDoList.objects.get(name="test")
        testitem = Item.objects.get(todolist, text="testitem")
        self.assertEqual(testitem.todolist.name, "test");
        self.assertEqual(testitem.name, "testitem")