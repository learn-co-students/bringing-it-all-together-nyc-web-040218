class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed

  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name text, breed text);"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  self

  end

  def self.create(data)
    dog = Dog.new(data)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id=?"
    result = DB[:conn].execute(sql, id)[0]

    dog = Dog.new({id: result[0],name: result[1],breed: result[2]})

  end

  def self.find_or_create_by(name:, breed:)
    result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !result.empty?
      result = result[0]
      dog = Dog.new({id: result[0],name: result[1], breed: result[2]})
    else
      dog = self.create({id: result[0], name: result[1], breed: result[2]})
    end
    dog


  end

  def self.find_by_name(name)
    sql = " SELECT * from dogs where name = ?"
    result = DB[:conn].execute(sql, name)[0]
    dog = Dog.new({id: result[0],name: result[1],breed: result[2]})
    # binding.pry
  end
  def self.new_from_db(result)
    dog = Dog.new({id: result[0],name: result[1],breed: result[2]})
    dog

  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end #class end
