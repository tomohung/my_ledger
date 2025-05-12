require "csv"

class TradeReportParserService
  # Define a struct to hold trade data
  Trade = Struct.new(:type, :direction, :price, :quantity, :date, :time)

  def initialize(csv_content)
    @csv_content = csv_content
  end

  def parse
    # Remove any BOM or special characters
    cleaned_content = @csv_content.gsub(/^\uFEFF/, "")
    # Clean up Excel-style formatting after successful parse
    cleaned_content = cleaned_content.gsub(/="([^"]*)"/, '\1')

    # Parse CSV content
    trades = []
    CSV.parse(cleaned_content, headers: true) do |row|
      # Extract and clean the data
      type = extract_type(row)
      direction = extract_direction(row)
      price = extract_price(row)
      quantity = extract_quantity(row)
      date = extract_date(row)
      time = extract_time(row)

      # Create trade object and add to array
      trades << Trade.new(type, direction, price, quantity, date, time)
    end

    trades
  end

  private

  def extract_type(row)
    # Handle both column names: '委託種類' and '種類'
    type_column = row["委託種類"] || row["種類"]
    type_column&.gsub(/[="]/, "")&.include?("平倉") ? "平倉" : "新倉"
  end

  def extract_direction(row)
    row["買賣別"]&.gsub(/[="]/, "")&.include?("買") ? "買" : "賣"
  end

  def extract_price(row)
    row["成交均價"]&.gsub(/[=",]/, "")&.to_f
  end

  def extract_quantity(row)
    # Handle both column names: '成交數量' and '成交量'
    quantity_column = row["成交數量"] || row["成交量"]
    quantity_column&.gsub(/[="]/, "")&.to_i
  end

  def extract_date(row)
    row["交易日期"]&.gsub(/[="]/, "")
  end

  def extract_time(row)
    row["成交時間"]&.gsub(/[="]/, "")
  end
end
