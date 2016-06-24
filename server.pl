# This file provided by Facebook is for non-commercial testing and evaluation
# purposes only. Facebook reserves all rights not expressly granted.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

use DBI;
use Time::HiRes qw(gettimeofday);
use Mojolicious::Lite;
use Mojo::JSON qw(encode_json decode_json);

my $dbh = DBI->connect("dbi:SQLite:dbname=comments.db","","");
my $comments_sth = comments_init($dbh);

app->static->paths->[0] = './public';

any '/' => sub { $_[0]->reply->static('index.html') };

any [qw(GET POST PUT DELETE)] => '/api/comments' => sub {
  my $self = shift;
  $self->res->headers->cache_control('no-cache');
  $self->res->headers->access_control_allow_origin('*');

  for ($self->req->method) {
    if ($_ eq 'POST') {
      for (qw(author text)) {
        return $self->render(text => $_ . ' not specified', code => 400) unless $self->param($_);
      }
      # 20% chance to fail to simulate errors
      return $self->render(text => 'Error', status => 500) if int(rand(5)) == 0;
      $comments_sth->{upsert}->execute(
        $self->param('id') || undef,
        $self->param('author'),
        $self->param('text')
      );
    } elsif ($_ eq 'PUT') {
      for (qw(id author text)) {
        return $self->render(text => $_ . ' not specified', code => 400) unless $self->param($_);
      }
      $comments_sth->{upsert}->execute(
        $self->param('id'),
        $self->param('author'),
        $self->param('text')
      );
    } elsif ($_ eq 'DELETE') {
      return $self->render(text => 'id not specified', code => 400) unless $self->param('id');
      $comments_sth->{delete}->execute(
        $self->param('id')
      );
    }
  }
  $comments_sth->{select}->execute();
  my $comments = $comments_sth->{select}->fetchall_arrayref({});
  if ($self->req->method eq 'HEAD') {
    $self->res->headers->content_type('application/json;charset=UTF-8');
    $self->res->headers->content_length(length(encode_json($comments)));
    $self->rendered(200);
  } else {
    $self->render(json => $comments);
  }
};
my $port = $ENV{PORT} || 3000;
app->start('daemon', '-l', "http://*:$port");

sub comments_init {
  my ($dbh) = @_;
  $dbh->do(<<EOT);
CREATE TABLE IF NOT EXISTS comments
(id INTEGER PRIMARY KEY, author TEXT, comment TEXT);
EOT
  my %sth;
  $sth{select} = $dbh->prepare(<<EOT);
SELECT * FROM comments
ORDER BY id ASC
EOT
  $sth{upsert} = $dbh->prepare(<<EOT);
INSERT OR REPLACE INTO comments
(id, author, comment)
VALUES
(?, ?, ?)
EOT
  $sth{delete} = $dbh->prepare(<<EOT);
DELETE FROM comments
WHERE id=?
EOT
  return \%sth;
}
