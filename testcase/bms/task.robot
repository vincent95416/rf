*** Settings ***
Library    Browser
Library    DateTime
Library    RequestsLibrary
Library    Collections
Resource    ../../resource/keywords.robot
Variables    ../../resource/environment_variables.py

*** Keywords ***
Initialize Browser
    New Browser    chromium    headless=${check_visible}
    New Context    viewport={'width': 1600, 'height': 900}    acceptDownloads=True

Continues_page
    New Browser    chromium    headless=${check_visible}    slowMo=1
    New Context    viewport={'width': 1600, 'height': 900}    acceptDownloads=True
    New Page    ${main_url}