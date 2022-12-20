modded class Apple
{
    override bool NameOverride(out string output)
    {
        string changeMe = "The Big Apple";

        if (changeMe != string.Empty)
        {
            output = changeMe;
            return true;
        }

        return false;
    }

    override bool DescriptionOverride(out string output)
    {
        string changeMe = "Thanks to Wardog for his help with hot loading <3";

        if (changeMe != string.Empty)
        {
            output = changeMe;
            return true;
        }

        return false;
    }
}
