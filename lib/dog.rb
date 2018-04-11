require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(attributes)
    # binding.pry
    attributes.each {|key, value| self.send(("#{key}="), value)}
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes)
    rocky = Dog.new(attributes)
    rocky.save
  end

  def self.find_by_id(identifier)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id= ?
    SQL
    DB[:conn].execute(sql, identifier).map {|row| Dog.new_from_db(row)}[0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name= ?
    SQL
    DB[:conn].execute(sql, name).map {|row| Dog.new_from_db(row)}[0]
  end

  def self.new_from_db(attributes)
    hash = {name: attributes[1], breed: attributes[2], id: attributes[0]}
    rocky = Dog.new(hash)
  end

  def self.find_or_create_by(attributes)
    # binding.pry
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name= ? AND breed= ?
    SQL

    rocky = DB[:conn].execute(sql, attributes[:name], attributes[:breed])

    if !rocky.empty?
      rocky_data = rocky[0]
      Dog.new_from_db(rocky_data)
    else
      rocky = self.create(name: attributes[1], breed: attributes[2])
    end
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name= ?, breed = ? WHERE id= ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
