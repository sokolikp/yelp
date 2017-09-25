# Project 2 - *yelp*

**yelp** is a Yelp search app using the [Yelp API](http://www.yelp.com/developers/documentation/v2/search_api).

Time spent: 11 hours spent in total

## User Stories

The following **required** functionality is completed:

- [X] Search results page
   - [X] Table rows should be dynamic height according to the content height.
   - [X] Custom cells should have the proper Auto Layout constraints.
   - [X] Search bar should be in the navigation bar (doesn't have to expand to show location like the real Yelp app does).
- [X] Filter page. Unfortunately, not all the filters are supported in the Yelp API.
   - [X] The filters you should actually have are: category, sort (best match, distance, highest rated), distance, deals (on/off).
   - [X] The filters table should be organized into sections as in the mock.
   - [X] You can use the default UISwitch for on/off states.
   - [X] Clicking on the "Search" button should dismiss the filters page and trigger the search w/ the new filter settings.
   - [X] Display some of the available Yelp categories (choose any 3-4 that you want).

The following **optional** features are implemented:

- [ ] Search results page
   - [X] Infinite scroll for restaurant results.
   - [ ] Implement map view of restaurant results.
- [ ] Filter page
   - [ ] Implement a custom switch instead of the default UISwitch.
   - [ ] Distance filter should expand as in the real Yelp app
   - [ ] Categories should show a subset of the full list with a "See All" row to expand. Category list is [here](http://www.yelp.com/developers/documentation/category_list).
- [ ] Implement the restaurant detail page.

The following **additional** features are implemented:

- [ ] List anything else that you can get done to improve the app functionality!

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. Best practices for organizing data structures (enums?) in a page where a lot of data is tracked by section or key. For instance, I often found myself trying to figure out which section I was in and to do something accordingly. I would also like to know best practices for passing data back and forth that contains string keys (e.g. passing filters data between view controllers) - it felt like bad code hygiene to use string keys in my filters and pass the object back and forth. Using something like enums/constant keys seems like a better way to structure this sort of data. Ideally I have time to go back and clean up some of those bad practices, but I would also like to get to optional features.
2. Best practices for API calls. How and when to load data asyncronously from multiple sources (e.g. part of a table cell requires data from endpoint A, and another part requires data from endpoint B).

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='https://image.ibb.co/gU9BuQ/yelp_results.gif' title='Result' width='' style="dislay:inline"/>    <img src='https://image.ibb.co/gf06Tk/yelp_filters.gif' title='Filters' width='' style="dislay:inline"/>

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Data organization and code hygiene was the most difficult aspect of this lab for me. I was moving somewhat slowly because I wanted to to my best to do things in the "Swift" way. I went back and forth on ways to structure my filters data in a way to was intuitive and easy to access from both view controllers. It would be nice to get more familiar with enums and best practices for using constants in these cases.

## License

    Copyright [2017] [Paul Sokolik]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
