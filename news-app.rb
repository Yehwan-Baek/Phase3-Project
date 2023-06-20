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
        STDIN.gets.chomp.to_i
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

        loop do
            puts "Enter your username (or enter 0 to cancel):"
            username = STDIN.gets.chomp

            if username == "0"
                puts "Registration canceled."
                return
            end

            if username.nil? || username.empty?
                puts "Username cannot be blank. Please try again."
                next
            end
          
            if User.exists?(username: username)
                puts "Username #{username} already exists. Please choose a different username."
                next
            end
          
            puts "Enter your password:"
            password = STDIN.gets.chomp
          
            user = User.new(username: username, password: password)
          
            if user.save
                puts "User #{username} registered successfully!"
            else
                puts "Failed to register user"
            end

            break
        end
    end

    def login_user
        puts "Logging in..."
        loop do
            puts "Enter your username (or enter 0 to cancel):"
            username = STDIN.gets.chomp

            if username == "0"
                puts "Logging in canceled."
                return
            end
        
            user = User.find_by(username: username)
            if user.nil?
                puts "Invalid username. Please try again"
                next
            end
        
            loop do
                puts "Enter your password (or enter 0 to cancel):"
                password = STDIN.gets.chomp

                if password == "0"
                    puts "Logging in canceled."
                    return
                end
        
                if user.password != password
                    puts "Invalid password. Please try again"
                    next
                end
        
                puts "Logged in successfully as #{username}!"
                self.current_user = user
                search_news_interface(username)
                return
            end
        end
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
        STDIN.gets.chomp.to_i
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
      
        category_number = nil
      
        loop do
            print "Enter the category number: "
            puts ""
            category_number = STDIN.gets.chomp.to_i
        
            break if NewsService::CATEGORIES.include?(category_number)
        
            puts "Invalid category number. Available categories:"
            NewsService::CATEGORIES.each { |key, value| puts "#{key}. #{value}" }
        end
      
        articles = NewsService.search_by_category(category_number)
        save_article(articles)
    end
      
    def search_by_keyword
        keyword = nil
        
        loop do
            puts "Enter a keyword to search for news:"
            keyword = STDIN.gets.chomp
            
            articles = NewsService.search_by_keyword(keyword)
            
            if articles.length == 0
                puts "No articles found for the keyword '#{keyword}'. Please try again."
            else
                save_article(articles)
                break
            end
        end
    end

    def save_article(articles)
        loop do
            puts ""
            puts "Enter the article number to save (or enter 0 to cancel):"
            article_number = STDIN.gets.chomp.to_i
            
            if article_number == 0
                puts "Cancelled."
                return
            elsif article_number < 1 || article_number > articles.length
                puts "Invalid article number."
                next
            end
            
            selected_article = articles[article_number - 1]
            
            if Headline.exists?(description: selected_article["description"], user_id: current_user.id)
                puts "Article already saved. Do you want to choose a different article? (Y/N)"
                response = STDIN.gets.chomp.upcase
                if response == "Y"
                    next
                else
                    puts "Cancelled."
                    return
                end
            end
            
            headline = Headline.new(
                user_id: current_user.id,
                title: selected_article["title"],
                description: selected_article["description"],
                url: selected_article["url"]
            )

            headline.attributes.except!("id")
            
            if headline.save
                puts ""
                puts "Article saved successfully!"
            else
                puts ""
                puts "Failed to save the article."
            end
        
            break
        end
    end
      

    def my_library
        saved_articles = Headline.where(user_id: current_user.id)

        if saved_articles.empty?
            puts "No saved articles yet"
            return
        end

        saved_articles.each_with_index do |article, index|
            puts ""
            puts "#{index + 1}. Title: #{article.title}"
            puts "   Description: #{article.description}"
            puts "   URL: #{article.url}"
        end
      
        loop do
            puts ""
            puts "Enter the article number to delete (or enter 0 to cancel):"
            article_number = STDIN.gets.chomp.to_i
        
            if article_number == 0
                puts "Cancelled."
                return
            elsif article_number < 1 || article_number > saved_articles.length
                puts "Invalid article number."
                next
            end
        
            selected_article = saved_articles[article_number - 1]
            if delete_article(selected_article)
                puts ""
                puts "Article deleted successfully!"
            else
                puts ""
                puts "Failed to delete the article."
            end
        
            break
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