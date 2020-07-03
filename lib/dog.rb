class Dog
    attr_accessor :name, :breed, :id
    def initialize(name:,breed:,id:nil)
        @name=name
        @breed=breed
        @id=id
    end
    def self.create_table
        sql="CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
        DB[:conn].execute(sql)
    end
    def self.drop_table
        sql="DROP TABLE dogs"
        DB[:conn].execute(sql)
    end
    def save
        sql="INSERT INTO dogs(name,breed) VALUES(?,?)"
        DB[:conn].execute(sql,self.name,self.breed)
        @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        Dog.new(name:name,breed:breed,id:@id)
    end
    def self.create(attributes)
        new_dog=Dog.new(attributes)
        new_dog.save
    end
    def self.new_from_db(attributes)
        id=attributes[0]
        name=attributes[1]
        breed=attributes[2]
        new_dog=Dog.new(name:name,breed:breed,id:id)
    end
    def self.find_by_id(id)
        sql="SELECT * FROM dogs WHERE id=?"
        DB[:conn].execute(sql,id).map do |row|
            self.new_from_db(row)
        end.first
    end
    def self.find_or_create_by(name:,breed:)
        sql="SELECT * FROM dogs WHERE name=? and breed=?"
        dog=DB[:conn].execute(sql,name,breed)
        if !dog.empty? 
            dog_new=dog[0]
            Dog.new(id:dog_new[0],name:dog_new[1],breed:dog_new[2])
        else
            self.create(name:name,breed:breed)
        end
    end
    def self.find_by_name(name)
        sql="SELECT * FROM dogs WHERE name=?"
        DB[:conn].execute(sql,name).map do |row|
            self.new_from_db(row)
        end.first
    end
    def update
        sql="UPDATE dogs SET name=?,breed=? WHERE id=?"
        DB[:conn].execute(sql,self.name,self.breed,self.id)
    end
end





