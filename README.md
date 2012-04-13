# RESTume

## About

RESTume was built by [Todd Bealmear](http://dd0t.com) to provide his resume as an API.

The resource list is below, but you can also check out the source on [GitHub](https://github.com/toddward/RESTume). 
A few notes on the source:

*	Written with Ruby on Sinatra.
*	No DataMapper - all resume data is saved in a YAML file. A database would have been overkill for this project.
*	This is my first real go with Ruby, but Sinatra made developing this super easy. It took me very little time to 
throw together with only a little previous Ruby experience.

## The API

All responses are JSON. There are no PUT or DELETE methods allowed on any of the resources. 
A single resource allows POST - this is to send a message to me if you're interested in getting in touch.

## Resources

*	**Resource: /resume**
	*	Description: Gives a high-level overview of the resume. Returns all data except education
	and experience lists have been truncated - full details can be had at their respective resources.
	*	Method: GET
*	**Resource: /resume/education**
	*	Description: Returns education details from the resume.
	*	Method: GET
*	**Resource: /resume/education/:id**
	*	Description: Returns the details of an educational institution I attended specified by ':id.'
	*	Method: GET
*	**Resource: /resume/experience**
	*	Description: Returns job experience details from the resume.
	*	Method: GET
*	**Resource: /resume/experience/:id**
	*	Description: Returns the details of a work experience specified by ':id.'
	*	Method: GET
*	**Resource: /resume/skills**
    *	Description: Returns the details of my technical expertise.
    *	Method: GET
*	**Resource: /resume/activities**
	*	Description: Returns the details of my extra-curricular activities.
	*	Method: GET
*	**Resource: /resume/interests**
	*	Description: Returns my list of interests.
	*	Method: GET
*	**Resource: /contact**
	*	Description: Allows you to contact me through the API.
	*	Method: POST
	*	Parameters (formatted as JSON):
		*	name: Your name
		*	email: Your email address
		*	body: Your message
