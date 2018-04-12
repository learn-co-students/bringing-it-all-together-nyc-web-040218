require 'pry'

class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        #how does it make the connection between key "name" and name as its value?
        @id = id
        @name = name
        @breed = breed
    end

    def self::create(hash)
        dog = Dog.new(hash)
        dog.save
        dog
    end

    def self::create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
            );
        SQL

        DB[:conn].execute(sql)
    end

    def self::drop_table
        DB[:conn].execute("DROP TABLE dogs;")
    end

    def self::new_from_db(array)
        id = array[0]
        name = array[1]
        breed = array[2]

        dog = Dog.new(id: id, name: name, breed: breed)
        dog.save
        dog
    end

    def self::find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            ORDER BY id ASC;
        SQL

        dog = Dog.new_from_db(DB[:conn].execute(sql, name)[0])

    end

    def self::find_by_id(id)
        db = DB[:conn].execute("SELECT * FROM dogs WHERE id = (?)", id)
        dog = Dog::new_from_db(db[0])
    end


    def self::find_or_create_by(attribute_hash)
        name = attribute_hash[:name]
        breed = attribute_hash[:breed]

        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")

        if dog.empty?
            dog = Dog.create(attribute_hash) 
        else
            doggo = Dog.new_from_db(dog[0])
        end
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?;
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def save
        if self.id.nil?
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        else
            self.update
            self
        end
    end


end