require 'pry'

class Dog

  attr_accessor :id, :name, :breed

  def initialize(hsh = {})
    @id = hsh[:id]
    @name = hsh[:name]
    @breed = hsh[:breed]
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      name TEXT,
      breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)[0]
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      Dog.new(id: id, name: self.name, breed: self.breed)
    end
  end

  def self.create(hash)
    dog = Dog.new(id: hash[:id], name: hash[:name], breed: hash[:breed])
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    Dog.new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    dog = DB[:conn].execute(sql, hash[:name], hash[:breed])
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = Dog.create(name: hash[:name], breed: hash[:breed])
    end
    dog
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    Dog.new_from_db(DB[:conn].execute(sql, name)[0])
  end


end
