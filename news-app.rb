require_relative 'config/environment'
require_relative 'app/news-service'

class NewsApp
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
        search_news_interface(username)
    end

    def search_news_interface(username)
        puts "Welcome, #{username}!"
        puts "You can search for news!"

        loop do
            choice = display_menu_search_for_news
            break if choice == 3
            perform_action_for_search_option(choice)
        end
    end

    def display_menu_search_for_news
        puts "Please select an option:"
        puts ""
        puts "1. Search by category"
        puts "2. Search by keyword"
        puts "3. Log out"
        puts ""
        gets.chomp.to_i
    end

    def perform_action_for_search_option(choice)
        case choice
        when 1
            search_by_category
        when 2
            search_by_keyword
        else
            puts "Invalid choice. Please try again"
        end
    end

    def search_by_category
    end

    def search_by_keyword

    def exit_app
        puts "Goodbye!"
        exit!
    end
end

app = NewsApp.new
app.start