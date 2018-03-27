defmodule VanMatcher.ResultsEmail do
  import Swoosh.Email

  def create(to, attachment_paths) when is_binary(to) and is_list(attachment_paths) do
    mail =
      new()
      |> to(to)
      |> from({"JD Van Matcher", "ben@justicedemocrats.com"})
      |> subject("Your van matched results are ready!")
      |> text_body(body())

    Enum.reduce(attachment_paths, mail, fn path, prev_mail ->
      attachment(prev_mail, path)
    end)
  end

  def body() do
    ~s[
Hi friend!

Your van matched results are ready and attached.

Have a good day!
]
  end
end
