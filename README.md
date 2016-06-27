# react-tutorial

Let's learn React!

# Post-Mortem

## Intro
Well, React was a fun library to learn, and really quite ingenious. It really speeds up programmatic DOM creation, and the way it interacts via ajax is much easier and faster to write than AngularJS. I think the initial scaffolding required for Angular would be worth it for full blown single page web applications, but the quick composing possible with React makes it ideal for use in websites and multipage web applications. If I had to choose one over the other, I'd pick React because it seems useful in more ways.

I think the difference is best shown with an antecdote. After I had learned Angular, I asked and was allowed to get together a demo at work. It took a day to get everything in place with the server, to create the views, controllers, and services and to debug (which I have to say is kind of ugly with both React and Angular, but maybe I'm missing a tool somewhere). The application just pulled information and didn't do any updates or deletes. With React, I had a similar app up and running on a "Google Friday" with plenty of time to add bells and whistles.

## What I like

One of things I really like about React is it's composable nature. It reflects the nature of HTML itself by emulating it with custom tags. Angular allows you to do this, but it's not nearly as quick to implement as React.

The other thing I like about it is it's easy to figure out what's going on behind the scenes with React. It's almost just a wrapper for all the ugly JavaScript necessary for programmatic DOM creation. Since the official tutorial used Babel as the scripting language, I can't speak to using React without it, but the code was very clear with Babel. It was very easy to look at a React class and see exactly what it was doing.
```javascript
      var CommentForm = React.createClass({
        getInitialState: function() {
          return {author: '', comment: ''};
        },
```
We've just defined and initalized the class and its state.
```javascript
        handleAuthorChange: function(e) {
          this.setState({author: e.target.value});
        },
        handleTextChange: function(e) {
          this.setState({comment: e.target.value});
        },
        handleSubmit: function(e) {
          e.preventDefault();
          var author = this.state.author.trim();
          var text = this.state.comment.trim();
          if(!text || !author) {
            return;
          }
          this.props.onCommentSubmit({author: author, comment: text});
          this.setState({author: '', comment: ''});
        },
```
The function names help here, but it's easy to see we are just making handler functions that accept a JavaScript event.
```javascript
        render: function() {
          return (
            <form className="commentForm" onSubmit={this.handleSubmit}>
              <fieldset>
                <legend>Enter a new comment</legend>
                <div id="error-posting-comment" style={{display: 'none'}} className="alert alert-danger" role="alert">
                  <span className="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
                  <span className="sr-only">Error:</span>
                  There was an error posting your comment. Please try again later.
                </div>
                <div className="form-group">
                  <label className="comment-author">Name</label>
                  <input
                    className="form-control"
                    id="comment-author"
                    type="text"
                    value={this.state.author}
                    onChange={this.handleAuthorChange}
                  />
                </div>
                <div className="form-group">
                  <label for="comment-text">Comment</label>
                  <input
                    className="form-control"
                    id="comment-text"
                    type="text"
                    placeholder="Say something..."
                    value={this.state.comment}
                    onChange={this.handleTextChange}
                  />
                </div>
                <input
                  className="btn btn-primary"
                  type="submit"
                  value="Post"
                />
              </fieldset>
            </form>
          );
        }
      });
```
Finally, our render function returns something that looks exactly like HTML. There are some changes like `className` instead of `class`, but it's more or less the same, and more importantly *readable*. It's easy to tell at a glance what it's doing, which means it's easy to spot mistakes. It's also safe by default, so you can throw whatever server variables you want in there. Jquery offers something similar, but it falls short.
```javascript
$.('<form class="commentForm" onSubmit="handleSubmit"><fieldset>');
```
I don't even want to finish that. Even if you built a string first it'd be terrible to update, and you'd have to worry about whether to use single or double quotation marks. If you are putting variables in it from the server, you also have to worry about injection attacks. Native JavaScript would be even worse.
```javascript
var form = document.createElement('form');
form.class = "commentForm";
form.onsubmit = handleSubmit;
var fieldset = document.createElement('fieldset');
form.appendChild(fieldset);
```
Although this can be shortened to something like this.
```javascript
var form = document.createElement('form');
form.class = "commentForm";
form.onsubmit = handleSubmit;
form.innerHTML = '<fieldset> \
... \
</fieldset>';
```
But this runs into the same issues as the jQuery, it's just not easy to look at and see what's going on. Isn't that kind of the whole purpose behind using a markup language anyway? To be able to see (with trained eyes of course) what the content of the document will be at a glance?

The last thing I'll say is that the tutorial showed that React components can be placed after the content in a page. This may not seem like much, but it greatly aids the browser in rendering the page quickly. The page rendering can't continue until script tags are parsed and executed. This isn't strictly true anymore since you can externalize the script and throw an `async` attribute on it, but sometimes you might just want to make an element or two for a single page. Not having to make a new file to download that comes with the price of yet another http handshake and all the other overhead that comes with downloading a file is a huge boon to flexibility.

## Conclusion

Although this is probably riddled with assumptions and misunderstandings due to the fact that I've only spent a weekend learning it, React is very powerful while being very clean looking. Reading React code and understanding the gist of what's going on is possible without actually *knowing* React, and I think that's a huge plus for it. Even if it's not adopted into the stack at my work, I'll definitely use it for personal projects.

It may seem like I bashed on Angular, but I really think that it's a good framework for MVC web applicatons. It definitely seems to be more for crafting whole applications rather than reusable components, so my comparison might not even be fair in the first place. Definitely check out both and see for yourself what they are both like.
