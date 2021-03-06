# Copyright (c) 2010, 2011 The University of Manchester, UK.
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#  * Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
#  * Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
#  * Neither the names of The University of Manchester nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission. 
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Author: Robert Haines

require 'test/unit'
require 't2-server'

# check for a server address passed through on the command line
if ARGV.size != 0:
  $address = ARGV[0]
  puts "Using server at #{$address}"
else
  # get a server address to test - 30 second timeout
  print "\nPlease supply a valid Taverna 2 Server address.\n\nNOTE that " +
    "these tests will fully load the server and then delete all the runs " +
    "that it has permission to do so - if you are not using security ALL " +
    "runs will be deleted!\n(leave blank to skip tests): "
  $stdout.flush
  if select([$stdin], [], [], 30)
    $address = $stdin.gets.chomp
  else
    puts "\nSkipping tests that require a Taverna 2 Server instance..."
    $address = ""
  end
end

# the testcases to run
require 'tc_paths'
if $address != ""
  $wkf_pass   = File.read("test/workflows/pass_through.t2flow")
  $wkf_lists  = File.read("test/workflows/empty_list.t2flow")
  $list_input = "test/workflows/empty_list_input.baclava"
  $file_input = "test/workflows/in.txt"

  require 'tc_server'
  require 'tc_run'
end
