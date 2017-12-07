require 'java'
java_import 'burp.IBurpExtender'
java_import 'burp.IMessageEditorTab'
java_import 'burp.IMessageEditorTabFactory'
java_import 'burp.IParameter'

$LOAD_PATH.unshift 'BLAH_BLAH_BLAH'
module Delegate; end
module Forwardable; end
require 'graphql'

class BurpExtender
  include IBurpExtender, IMessageEditorTabFactory

  attr_accessor :callbacks, :helpers

  def registerExtenderCallbacks(callbacks)
    # keep a reference to our callbacks object
    @callbacks = callbacks

    # obtain an extension helpers object
    @helpers = callbacks.getHelpers

    # set our extension name
    callbacks.setExtensionName 'GraphQL Beautifier'

    # register ourselves as a message editor tab factory
    callbacks.registerMessageEditorTabFactory(self)

    return
  end

  #
  # implement IMessageEditorTabFactory
  #

  def createNewInstance(controller, editable)
    # create a new instance of our custom editor tab
    GraphQLBeautifierTab.new self, controller, editable
  end
end

#
# class implementing IMessageEditorTab
#

class GraphQLBeautifierTab
  include IMessageEditorTab

  def initialize(extender, controller, editable)
    @extender = extender
    @editable = editable

    # create an instance of Burp's text editor, to display our deserialized data
    @txtInput = extender.callbacks.createTextEditor
    @txtInput.setEditable editable
  end

  #
  # implement IMessageEditorTab
  #

  def getTabCaption()
		'GraphQL Beautifier'
  end

  def getUiComponent()
      @txtInput.getComponent
  end

	def isGraphQL(content)
		requestInfo = @extender.helpers.analyzeRequest(content)
		requestInfo.getHeaders.to_a.each do |header|
			return true if header.match /Content-Type: application\/graphql/i
		end
	
		false
	end

  def isEnabled(content, isRequest)
    # enable this tab for requests containing a data parameter
    isRequest and isGraphQL(content)
  end

  def setMessage(content, isRequest)
    if content.nil?
      # clear our display
      @txtInput.setText nil
      @txtInput.setEditable false
    else
			begin
				requestInfo = @extender.helpers.analyzeRequest(content)
				body = content[requestInfo.getBodyOffset()..-1].to_s
				@txtInput.setText @extender.helpers.stringToBytes(GraphQL.parse(body).to_query_string)
			rescue => e
				@txtInput.setText @extender.helpers.stringToBytes("Unable to parse GraphQL: #{e.to_s}")
			end
      @txtInput.setEditable @editable
    end

    # remember the displayed content
    @currentMessage = content

    return
  end

  def getMessage()
    # determine whether the user modified the deserialized data
    if @txtInput.isTextModified
			begin
				requestInfo = @extender.helpers.analyzeRequest(@currentMessage)
				bodyBytes = @extender.helpers.stringToBytes(GraphQL.parse(@txtInput.getText.to_s).to_query_string)
				@extender.helpers.buildHttpMessage(requestInfo.getHeaders(), bodyBytes)
			rescue => e
				@currentMessage
			end
    else
			@currentMessage
    end
  end

  def isModified()
    @txtInput.isTextModified
  end

  def getSelectedData()
    @txtInput.getSelectedText
  end
end
