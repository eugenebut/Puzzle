#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from google.appengine.ext.webapp import template
import os
import webapp2


def GetPath(file_name):
	return os.path.join(os.path.dirname(__file__), file_name)


class MainHandler(webapp2.RequestHandler):
    def get(self):
        self.response.out.write(template.render(GetPath('index.html'), {}))


class FAQHandler(webapp2.RequestHandler):
    def get(self):
        self.response.out.write(template.render(GetPath('faq.html'), {}))


class ContactUsHandler(webapp2.RequestHandler):
    def get(self):
        self.response.out.write(template.render(GetPath('contact_us.html'), {}))


app = webapp2.WSGIApplication([('/', MainHandler),
							   ('/faq', FAQHandler),
  							   ('/contact_us', ContactUsHandler),
 							  ], debug=True)
