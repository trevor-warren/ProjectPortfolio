#include "Rope.h"

#include <iostream>

const char* inputs[] = {
	"\n test\n",
	"\n apple\n",
	"\n bananana\n",
	"\n five\n",
	"\n hihihi\n",
	"\n hello world\n",
	"\n abandon all hope ye who enter here\n",
	"\n I AM THE DESTROYER OF CODE AND ALGORITHMS I WILL EAT YOUR ROPE FOR BREAKFAST DO NOT TRY TO RESIST FOR I AM THE DESTROYER\n",
	"\n SMOKESCREEN\n",
	"\n smoke test\n",
	"\n fuck all ur shit\n"
};

const int numInputs = sizeof(inputs) / sizeof(char*);

int main()
{
	{
		Rope adope;

		for (int i = 0; i < 1000000; ++i)
		{
			int at = 0;
			int length = adope.GetLength();

			if (length > 0)
				at = rand() % length;

			adope.Insert(at, inputs[rand() % numInputs]);

			//if (!adope.Validate())
			//	throw "wat do";
		}

		for (int i = 0; i < 1000000 && adope.GetLength() > 0; ++i)
		{
			adope.Remove(rand() % adope.GetLength(), rand() % 25);
		}

		std::string myhumps = adope;

		if (!adope.Validate())
			throw "wat do";

//		std::cout << myhumps << std::endl;
	}
//
//	std::cout << "wooo we did it hurray!" << std::endl;
//	std::cout << "the rope survived!" << std::endl;

	return 0;
}