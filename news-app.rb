require_relative 'config/environment'
require_relative 'app/news-service'

class NewsApp
    attr_accessor :current_user
    
    def start
        puts "Welcome to the News App!"
        
        loop do
            choice = display_menu
            perform_action(choice)
        end
    end

    def display_menu
        puts "Please select an option:"
        puts ""
        puts "1. Register"
        puts "2. Login"
        puts "3. Exit"
        puts ""
        gets.chomp.to_i
    end

    def perform_action(choice)
        case choice
        when 1
            register_user
        when 2
            login_user
        when 3
            exit_app
        else
            puts "Invalid choice. Please try again"
        end
    end

    def register_user
        puts "Registering a user..."
        puts "Enter your username:"
        username = gets.chomp

        if User.exists?(username:username)
            puts "Username #{username} already exists. Please choose a different username."
            display_menu
        end

        puts "Enter your password:"
        password = gets.chomp

        user = User.new(username: username, password: password)

        if user.save
            puts "User #{username} registered successfully!"
        else
            puts "Failed to register user"
        end
    end

    def login_user
        puts "Loggin in..."
        puts "Enter your username:"
        username = gets.chomp
        puts "Enter your password:"
        password = gets.chomp
        
        user = User.find_by(username: username)

        if user.nil? || user.password != password
            puts "Invalid username or password. Please try again"
            display_menu
        end

        puts "Logged in successfullly as #{username}!"
        self.current_user = user
        search_news_interface(username)
    end

    def search_news_interface(username)
        puts "Welcome, #{username}!"
        puts "You can search for news!"

        loop do
            choice = display_menu_search_for_news
            break if choice == 4
            perform_action_for_search_option(choice)
        end
    end

    def display_menu_search_for_news
        puts "Please select an option:"
        puts ""
        puts "1. Search by category"
        puts "2. Search by keyword"
        puts "3. My Library"
        puts "4. Log out"
        puts ""
        gets.chomp.to_i
    end

    def perform_action_for_search_option(choice)
        case choice
        when 1
            search_by_category
        when 2
            search_by_keyword
        when 3
            my_library
        else
            puts "Invalid choice. Please try again"
        end
    end

    def search_by_category
        puts "Available categories:"
        NewsService::CATEGORIES.each { |key, value| puts "#{key}. #{value}" }
        print "Enter the category number: "
        puts ""
        category_number = gets.chomp.to_i
      
        if category_number.nil?
          puts "Invalid category number. Available categories:"
          NewsService::CATEGORIES.each { |key, value| puts "#{key}. #{value}" }
          return
        end
      
        articles = NewsService.search_by_category(category_number)
        save_article(articles)
    end
      
    def search_by_keyword
        puts "Enter a keyword to search for news:"
        keyword = gets.chomp
          
        articles = NewsService.search_by_keyword(keyword)
        save_article(articles)
    end

    def save_article(articles)
        puts ""
        puts "Enter the article number to save (or enter 0 to cancel):"
        article_number = gets.chomp.to_i
      
        if article_number == 0
          puts "Cancelled."
          return
        elsif article_number < 1 || article_number > articles.length
          puts "Invalid article number."
          return
        end
      
        selected_article = articles[article_number - 1]
      
        if Headline.exists?(title: selected_article["title"], user_id: current_user.id)
          puts "Article already saved."
          return
        end
      
        headline = Headline.new(
          user_id: current_user.id,
          title: selected_article["title"],
          description: selected_article["description"],
          url: selected_article["url"]
        )
      
        if headline.save
          puts ""
          puts "Article saved successfully!"
        else
          puts ""
          puts "Failed to save the article."
        end
    end
      

    def my_library
        saved_articles = Headline.where(user_id: current_user.id)
        saved_articles.each_with_index do |article, index|
          puts ""
          puts "#{index + 1}. Title: #{article.title}"
          puts "   Description: #{article.description}"
          puts "   URL: #{article.url}"
        end
      
        puts ""
        puts "Enter the article number to delete (or enter 0 to cancel):"
        article_number = gets.chomp.to_i
      
        if article_number == 0
          puts "Cancelled."
          return
        elsif article_number < 1 || article_number > saved_articles.length
          puts "Invalid article number."
          return
        end
      
        selected_article = saved_articles[article_number - 1]
        if delete_article(selected_article)
          puts ""
          puts "Article deleted successfully!"
        else
          puts ""
          puts "Failed to delete the article."
        end
    end
      
    def delete_article(article)
        article.destroy
    end
      
    def exit_app
        puts "Goodbye!"
        exit!
    end
end

app = NewsApp.new
app.start