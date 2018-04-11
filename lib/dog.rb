class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
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
      );
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs;
      SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES(?,?);
      SQL

    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.new_from_db(data_record)
    Dog.new(id: data_record[0], name: data_record[1], breed: data_record[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
        WHERE id = ?;
      SQL

    DB[:conn].execute(sql, id).map do |data_record|
      self.new_from_db(data_record)
    end.first
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
        WHERE name = ?;
      SQL

    DB[:conn].execute(sql, name).map do |data_record|
      self.new_from_db(data_record)
    end.first
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(attributes)
    dog = Dog.new(name: attributes[:name], breed: attributes[:breed])
    dog.save
  end

  def self.find_or_create_by(attributes)
    sql = <<-SQL
      SELECT * FROM dogs
        WHERE breed = ?
    SQL

    data_records = DB[:conn].execute(sql, attributes[:breed])

    if data_records.empty?
      self.create(attributes)
    else
      data_records.map do |data_record|
        self.new_from_db(data_record)
      end.first
    end
  end
end
