class Dog
    attr_accessor :id, :name, :breed

    def initialize(attributes)
        attributes.each do |key, value|
            self.send("#{key}=", value)
        end
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE dogs (
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
        if self.id
          self.update
        else
          sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
          SQL
          DB[:conn].execute(sql, self.name, self.breed)
          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def update
        sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ?
        WHERE dogs.id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog = self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE dogs.id = ?
        SQL
        self.new_from_db(DB[:conn].execute(sql, id)[0])
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
              SELECT *
              FROM dogs
              WHERE name = ?
              AND breed = ?
              LIMIT 1
            SQL
    
        row = DB[:conn].execute(sql, name, breed)[0]
        
        if row
            dog = self.new_from_db(row)
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE dogs.name = ?
        SQL

        dog = DB[:conn].execute(sql, name)[0]
        self.new_from_db(dog)
    end
end