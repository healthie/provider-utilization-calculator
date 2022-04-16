# Provider Utilization Calculator 
This is an example of how to calculate and forecast provider utilization. The scripts shows how you can utilize the Healthie API to determine this information.

<img width="683" alt="sample_script_output" src="https://user-images.githubusercontent.com/1649883/163689145-382031ae-9d41-4720-a1a7-21d0c6d711be.png">

# Usage

First, make sure you have a Healthie API key and account. If you don't have one, you can go to https://www.gethealthie.com/api and request access.

Second, clone the repository to your computer, and install dependencies.

```bash
git clone https://github.com/healthie/provider-utilization-calculator.git
cd provider-utilization-calculator
bundle install
```

Third, adjust the script to add in your API key, adjust the API URL to the correct environemtn,  and set desired date range.


# Running the script

The script can be run as a normal Ruby script
```bash
ruby ./utilization_queries.rb
```
