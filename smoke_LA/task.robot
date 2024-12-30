*** Settings ***
Library    Browser
Library    DateTime
Resource    ../resource/keywords.robot
Variables    ../resource/environment_variables.py

*** Keywords ***
Initialize Browser
    New Browser    chromium    headless=False
    New Context    viewport={'width': 1600, 'height': 900}    acceptDownloads=True
    Log    Testing version ${VERSION} in ${ENV} environment

Continuous page
    New Browser    chromium    headless=True    slowMo=1
    New Page    ${main_url}

Add url
    New Browser    chromium    headless=False    slowMo=1
    New Page    ${main_url}&uid=${uid}&title=robot_page&em=Add

Edit url
    New Browser    chromium    headless=False    slowMo=1
    New Page    ${main_url}&uid=${uid}&title=robot_page&em=Edit

Report url
    New Browser    chromium    headless=False    slowMo=1
    New Page    ${url}History_Report_List.html?token=${token}&language=en