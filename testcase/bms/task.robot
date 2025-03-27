*** Settings ***
Library    Browser
Library    DateTime
Library    RequestsLibrary
Library    Collections
Resource    ../../resource/keywords.robot
Variables    ../../resource/environment_variables.py

*** Keywords ***
Initialize Browser
    #New Browser    chromium    headless=${check_visible}
    New Browser    chromium    headless=True
    New Context    viewport={'width': 1600, 'height': 900}    acceptDownloads=True
    #Log    Testing version ${VERSION} in ${environment} environment

Continuous page
    New Browser    chromium    headless=True    slowMo=1
    New Page    ${main_url}