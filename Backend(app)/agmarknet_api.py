
from flask import Flask, request, jsonify
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from datetime import datetime, timedelta


app = Flask(__name__)


def scrape_price_data(commodity, state, district, market, days):
    print(f"Starting scrape for: {commodity}, {state}, {district}, {market} for the last {days} days.")

    date_to = datetime.now()
    date_from = date_to - timedelta(days=days)
    date_to_str = date_to.strftime('%d-%b-%Y')
    date_from_str = date_from.strftime('%d-%b-%Y')
    print(f"Searching for data between {date_from_str} and {date_to_str}")

    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--window-size=1920,1080")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--disable-gpu")
    
    driver = webdriver.Chrome(options=chrome_options)
    
    response_data = {
        "query": {
            "commodity": commodity,
            "state": state,
            "district": district,
            "market": market,
            "days": days
        },
        "results": [],
        "error": None
    }

    try:
        driver.get("https://agmarknet.gov.in")
        wait = WebDriverWait(driver, 30)

        commodity_dropdown = wait.until(EC.element_to_be_clickable((By.ID, "ddlCommodity")))
        Select(commodity_dropdown).select_by_visible_text(commodity)

        state_dropdown = wait.until(EC.element_to_be_clickable((By.ID, "ddlState")))
        Select(state_dropdown).select_by_visible_text(state)
        

        wait.until(EC.presence_of_element_located((By.XPATH, f"//select[@id='ddlDistrict']/option[text()='{district}']")))
        Select(driver.find_element(By.ID, "ddlDistrict")).select_by_visible_text(district)


        wait.until(EC.presence_of_element_located((By.XPATH, f"//select[@id='ddlMarket']/option[text()='{market}']")))
        Select(driver.find_element(By.ID, "ddlMarket")).select_by_visible_text(market)

        date_from_input = wait.until(EC.presence_of_element_located((By.ID, "txtDate")))
        driver.execute_script(f"arguments[0].value = '{date_from_str}';", date_from_input)
        date_to_input = wait.until(EC.presence_of_element_located((By.ID, "txtDateTo")))
        driver.execute_script(f"arguments[0].value = '{date_to_str}';", date_to_input)

        driver.find_element(By.ID, "btnGo").click()
        
        print("Waiting for results table to load...")
        wait.until(EC.presence_of_element_located((By.ID, "cphBody_GridPriceData")))
        print("Results table loaded.")

        if "No records found" in driver.page_source:
            response_data["error"] = f"No price data available for the selected criteria in the last {days} days."
        else:
            price_rows = driver.find_elements(By.XPATH, "//*[@id='cphBody_GridPriceData']/tbody/tr")
            
            for row in price_rows[1:]:
                columns = row.find_elements(By.TAG_NAME, "td")
                
                if len(columns) > 8:
                    record = {
                        "date": columns[9].text,
                        "min_price": columns[6].text,
                        "max_price": columns[7].text,
                        "modal_price": columns[8].text
                    }
                    response_data["results"].append(record)
            print(f"Scrape successful. Found {len(response_data['results'])} records.")

    except Exception as e:
        error_message = f"An error occurred: {str(e)}"
        print(error_message)
        response_data["error"] = error_message
        
    finally:
        driver.quit()
        
    return response_data


@app.route('/price', methods=['GET'])
def get_price():
    commodity_query = request.args.get('commodity')
    state_query = request.args.get('state')
    district_query = request.args.get('district')
    market_query = request.args.get('market')
    days_query = request.args.get('days', default=7, type=int)

    if not all([commodity_query, state_query, district_query, market_query]):
        return jsonify({"error": "Missing required parameters. Please provide 'commodity', 'state', 'district', and 'market'."}), 400

    data = scrape_price_data(commodity_query, state_query, district_query, market_query, days_query)
    
    return jsonify(data)


if __name__ == '__main__':
    app.run(debug=True,host='0.0.0.0',port=5000)

