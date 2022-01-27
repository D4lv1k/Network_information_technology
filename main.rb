#Імпорт бібліотек
require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'json'

#Імпорт файлу, який містить функцію для конвертації json в csv
require_relative 'json_to_csv'


MAX_PAGES     = 10
URL           = "https://auto.ria.com/uk/legkovie/city/chernovczy/?page=%d"
JSON_FILENAME = "items.json"
CSV_FILENAME  = "items.csv"

items = []
# цикл від 0 до 10 (MAX_PAGES)
MAX_PAGES.times do |page_number|
  # Друкуємо в консоль яку сторінку парсимо
  puts "Parsing page #{page_number + 1}"
  # Отримуємо вміст
  page = Nokogiri::HTML(URI.open(URL % [page_number + 1]))

  #для кожного оголошення на сторінці
  items += page.css('section.ticket-item').map do |item|
    #отримємо блок з фотографією та інформацією машини
    content  = item.at('div.content-bar')
    car_info = item.at('div.hide')

    #отримуємо фотографію
    img_url = content.at('div.ticket-photo > a > picture img')['src']
    info    = content.at('div.content')

    #отримємо відстань, пробіг, місто 
    price        = info.at('div.price-ticket')['data-main-price']
    distance     = info.at('li.js-race').text[/\d+/].to_i
    location     = info.at('li.js-location').text.split.first
    has_accident = !info.at("div.base_information > span[data-state='state']").nil?

    # повертаємо вміст в HASH структурі
    {
      :id              => item['data-advertisement-id'],
      :brand           => car_info['data-mark-name'],
      :model           => car_info['data-model-name'],
      :year            => car_info['data-year'],
      :price           => price,
      :distance        => distance,
      :location        => location,
      :was_in_accident => has_accident,
      :img_url         => img_url,
    }
  #Якщо якась помилка друкуэмо в консоль повыдомлення
  rescue
    puts "Parse item error. Skipping..."
  end
end

#Рахуэмо кількість помилок
errors_count = items.count(nil)

#Виводимо інформацію про к-сть успіхів і к-сть помилок
puts "\nSuccessfully parsed items: #{items.count - errors_count}"
puts "Errors: #{errors_count}"

#Записуємо в json файл
File.write(JSON_FILENAME, JSON.pretty_generate(items.compact))

#Конвертуємо цей файл в csv
convert_json_to_csv(JSON_FILENAME, CSV_FILENAME)



