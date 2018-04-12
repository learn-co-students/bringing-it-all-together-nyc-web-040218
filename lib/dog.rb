require 'pry'
class Dog

  attr_accessor :name, :breed, :id

  def initialize(attr_hash)
    attr_hash.each do |att_key, attr_val|
      self.send(("#{att_key}="), attr_val)
    end
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def self.new_from_db(attr_a)
    #takes array from SQL db and sends it to initialize w/ params as hash
    self.new({id: attr_a[0], name: attr_a[1], breed: attr_a[2]})
  end

  def self.find_by_name(name_s)
    #UNFINISHED
    sql=<<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    SQL

    stu_a = DB[:conn].execute(sql, name_s)[0]
    new_from_db(stu_a)
  end

  def update
    sql=<<-SQL
    UPDATE dogs
    SET name = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.id)
  end

  def save
    if !self.id.nil?
      binding.pry
      self.update
    else
      sql=<<-SQL
      INSERT INTO dogs
      (name, breed)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(attr_h)
    dog_o = new(attr_h)
    dog_o.save
  end

  def self.find_by_id(id_i)

    sql=<<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL

    attr_a = DB[:conn].execute(sql,id_i)[0]

    self.new_from_db(attr_a)
  end

  def self.find_or_create_by(attr_h)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attr_h[:name], attr_h[:breed])
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new_from_db(dog_data)
    else
      dog = Dog.create(attr_h)
    end
    dog
  end

end
