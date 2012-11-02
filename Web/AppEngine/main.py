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

import cgi
import logging
import os
import webapp2

from google.appengine.api import mail
from google.appengine.ext.webapp import template


def GetPath(file_name):
  return os.path.join(os.path.join(os.path.dirname(__file__), 'templates', file_name))


class MainHandler(webapp2.RequestHandler):

    def get(self, tab):
        self.render_tab(tab)

    def post(self, tab):
      sender = "{0} <{1}>".format(self.request.get('user_name'), self.request.get('email'))
      mail.send_mail(sender=sender,
                     to="but.eugene@gmail.com",
                     subject="Puzzle question",
                     body=self.request.get('question'))

      self.render_tab(tab, alert_title="Thank you for your question!",
                           alert_message="You should hear from up soon.")

    def render_tab(self, tab, alert_title="", alert_message=""):
        map = {'faq': 'faq.html'}
        context = {'alert_title': alert_title, 'alert_message': alert_message}
        self.response.out.write(template.render(GetPath(map.get(tab, 'index.html')), context))


app = webapp2.WSGIApplication([(r'/(.*)', MainHandler)], debug=True)
