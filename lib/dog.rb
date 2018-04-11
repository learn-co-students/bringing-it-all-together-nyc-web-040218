require 'pry'

class Dog
  attr_accessor :name, :breed, :id
  # attr_reader :id

  def initialize(id:nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
              id INTEGER PRIMARY KEY,
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
    sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
          SQL
    DB[:conn].execute(sql, @name, @breed)
    @id = retrieve_hightest_id
    self
  end

  def self.create(hash)
    self.new(hash).save
  end

  def self.find_by_id(id)
    sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
          SQL
    hi = DB[:conn].execute(sql, id).flatten
    dog = Dog.new({id: hi[0], name: hi[1], breed: hi[2]})
    dog
  end

  def self.find_or_create_by(hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed]).flatten
    if !dog.empty?
      new_dog = Dog.new({id: dog[0], name: dog[1], breed: dog[2]})
      new_dog
    else
      new_dog = self.create(hash)
      new_dog
    end
  end

  def self.new_from_db(row)
    self.create(self.create_hash(row))
  end

  def self.find_by_name(name)
    sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?
          SQL
    arr = DB[:conn].execute(sql, name).flatten
    dog = self.new(self.create_hash(arr))
    dog
  end

  def update
    sql = <<-SQL
            UPDATE dogs SET name = ?, breed =? WHERE id = ?
          SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  private
  def retrieve_hightest_id
    sql = <<-SQL
            SELECT last_insert_rowid() FROM dogs
          SQL
    DB[:conn].execute(sql)[0][0]
  end

  def self.create_hash(arr)
    hash = {id: arr[0], name: arr[1], breed: arr[2]}
    hash
  end
end
