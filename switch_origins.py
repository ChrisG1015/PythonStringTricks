
You can achieve this using a simple Python if-else statement and string manipulation. You can check if the input string contains the pattern "Cloudfront for {CHARACTERS} livestreaming" and then extract the {CHARACTERS} if present. Otherwise, the string will remain unchanged. Here's the code to do that:

python
Copy code
def remove_cloudfront_description(input_string):
    target_pattern = "Cloudfront for "
    if input_string.startswith(target_pattern):
        start_index = len(target_pattern)
        end_index = input_string.find(" livestreaming")
        if end_index != -1:
            return input_string[start_index:end_index]
    return input_string
