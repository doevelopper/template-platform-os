#ifndef MSF_EMS_DHS_CALCULATOR_HPP
#define MSF_EMS_DHS_CALCULATOR_HPP

namespace msf::ems:dhs
{
	class Calculator
	{
		double result = std::numeric_limits<double>::quiet_NaN();
	public:
		Calculator();
		Calculator(const Calculator&) = default;
		Calculator(Calculator&&) = default;
		Calculator& operator=(const Calculator&) = default;
		Calculator& operator=(Calculator&&) = default;
		virtual ~Calculator();

	protected:

	private:
		void addition();
		void multiplication();
		void division();
		void substraction();
	};
}
#endif

