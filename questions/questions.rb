require 'sqlite3'
require 'singleton'

class QuestionsDBConnection < SQLite3::Database

  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end

end

class Users
  attr_accessor :fname, :lname

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM users")
    data.map {|datum| Users.new(datum)}
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def create
    raise "#{self} already in database" if @id

    QuestionsDBConnection.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users(fname, lname)
      VALUES
       (?, ?)
    SQL

    # @id = QuestionsDBConnection.insta?nce.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id

    QuestionsDBConnection.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end

  def self.find_by_id(id)
    user = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    Users.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    Users.new(user.first)
  end

  def self.authored_questions(id)
    Questions.find_by_author_id(id)
  end

  def self.authored_replies(id)
    Replies.find_by_author_id(id)
  end

  def followed_questions
    QuestionsFollow.followers_for_user_id(@id)
  end

end

class Questions
  attr_accessor :title, :body, :user_id

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM questions")
    data.map {|datum| Questions.new(datum)}
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def create
    raise "#{self} already in database" if @id

    QuestionsDBConnection.instance.execute(<<-SQL, @title, @body, @user_id)
      INSERT INTO
        questions(title, body, user_id)
      VALUES
       (?, ?, ?)
    SQL

    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id

    QuestionsDBConnection.instance.execute(<<-SQL, @title, @body, @user_id, @id)
      UPDATE
        questions
      SET
        title = ?, body = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end

  def self.find_by_id(id)
    question = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    Questions.new(question.first)
  end

  def self.find_by_author_id(id)
    questions = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL
    questions.map { |datum| Questions.new(datum) }
  end

  def author

    name = QuestionsDBConnection.instance.execute(<<-SQL, self.user_id)
      SELECT
        fname, lname
      FROM
        users
      WHERE
        id = ?
    SQL
    Users.new(name.first)
  end

  def followers
    QuestionsFollow.followers_for_question_id(@id)
  end

  def self.most_followed(n)
    QuestionsFollow.most_followed_question(n)
  end
end


class Replies
  attr_accessor :question_id, :parent_id, :user_id, :reply

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM replies")
    data.map {|datum| Replies.new(datum)}
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
    @reply = options['reply']
  end

  def create
    raise "#{self} already in database" if @id

    QuestionsDBConnection.instance.execute(<<-SQL, @question_id, @parent_id, @user_id, @reply)
      INSERT INTO
        users(question_id,parent_id,user_id,reply)
      VALUES
       (?, ?, ?, ?)
    SQL

  end

  def update
    raise "#{self} not in database" unless @id

    QuestionsDBConnection.instance.execute(<<-SQL, @question_id, @parent_id, @user_id, @reply, @id)
      UPDATE
        users
      SET
        question_id = ?, parent_id = ?, user_id = ?, reply = ?
      WHERE
        id = ?
    SQL
  end

  def self.find_by_author_id(id)
    reply = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    Replies.new(reply.first)
  end

  def self.find_by_question_id(id)
    reply = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    Replies.new(reply.first)
  end

  def question
    question = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    Questions.new(question.first)
  end

  def parent_reply
    parent = QuestionsDBConnection.instance.execute(<<-SQL, parent_id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    Replies.new(parent.first)
  end

end


class QuestionLikes
  attr_accessor :user_id, :question_id

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM question_likes")
    data.map {|datum| QuestionLikes.new(datum)}
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def create
    raise "#{self} already in database" if @id

    QuestionsDBConnection.instance.execute(<<-SQL, @user_id, @question_id)
      INSERT INTO
        question_likes(user_id, question_id)
      VALUES
       (?, ?)
    SQL

  end

  def self.find_by_user_id(id)
    user = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        user_id = ?
    SQL
    QuestionLikes.new(user.first)
  end

  def self.find_by_question_id(id)
    user = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        question_id = ?
    SQL
    QuestionLikes.new(user.first)
  end

  def likers(question_id)

    people = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_likes
      JOIN users
        ON users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL

  end

  def num_likes_for_question_id(question_id)
    people = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*)
      FROM
        question_likes
      JOIN users
        ON users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL
  end

  def liked_questions_for_user_id(user_id)

    people = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT DISTINCT
        questions.*
      FROM
        question_likes
      JOIN
        questions ON questions.id = question_likes.question_id
      WHERE
        question_likes.user_id = ?
    SQL


  end


end




class QuestionsFollow

  attr_reader :user_id, :question_id

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM questions_follow")
    data.map {|datum| QuestionLikes.new(datum)}
  end

  def initialize(options)
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def self.followers_for_question_id(question_id)

    followers = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT DISTINCT
        fname, lname
      FROM
        questions_follow
      JOIN
        users ON users.id = questions_follow.user_id
      WHERE
        questions_follow.question_id = ?
    SQL

    followers.map{ |el| Users.new(el) }
  end

  def self.followers_for_user_id(user_id)

    followers = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT DISTINCT
        questions.title, questions.body, questions.user_id
      FROM
        questions_follow
      -- JOIN
      --   replies ON replies.user_id = questions_follow.user_id
      JOIN
        questions ON questions.id = question_id
      WHERE
        questions_follow.user_id = ?
    SQL

    followers.map{ |el| Questions.new(el) }
  end

  def most_followed_question(n)
    top_results = QuestionsDBConnection.instance.execute(<<-SQL, n)
    SELECT
      questions.*, count(questions.id) as num_followers
    FROM
      questions_follow
      JOIN questions ON questions.id = questions_follow.question_id
    GROUP BY questions_follow.question_id
    ORDER BY COUNT(questions.id) DESC
    LIMIT ?
    SQL
    top_results.map { |q| Questions.new(q) }
  end

  def average_karma

    answer = QuestionsDBConnection.instance.execute(<<-SQL)
    SELECT

    FROM
    
    WHERE
    SQL

  end


end
