require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :name, :grade, :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]  

  def initialize(name, grade, id=nil)
    @name = name
    @grade= grade
  end

  def self.create_table
    sql="CREATE TABLE IF NOT EXISTS students
    (id INTEGER PRIMARY KEY, 
      name TEXT, 
      grade INTEGER
      );"

    DB[:conn].execute(sql)
  end

  def self.drop_table 
    sql = "DROP TABLE students"
    DB[:conn].execute(sql)
  end

  def save
    if @id != nil 
      self.update
    else
      sql = <<-SQL 
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM 
        students")[0][0]
    end
  end

  def update 
    sql = <<-SQL 
    UPDATE students SET name = ?, grade = ?
    WHERE id = ? 
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade) 
    new_student = self.new(name, grade)
    new_student.save
    new_student 
  end

  def self.new_from_db(row) 
    new_student = self.create(row[1], row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
    student_row = DB[:conn].execute(sql, name)
    
    new_student = self.new(student_row[0][1], student_row[0][2])
    new_student.id = DB[:conn].execute("SELECT last_insert_rowid() FROM 
        students")[0][0]
    new_student
  end



end
