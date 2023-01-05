from django.test import TestCase
from .models import Teacher
# Create your tests here.


# Adding an object and accessing it
class TeacherTest(TestCase):
    def setUp(self):
        Teacher.objects.create(name="test", age=20)

    def test_object_name(self):
        teachertest = Teacher.objects.get(name="test", age=20)
        self.assertEqual(teachertest.name, "test")
        self.assertEqual(teachertest.age, 20)
