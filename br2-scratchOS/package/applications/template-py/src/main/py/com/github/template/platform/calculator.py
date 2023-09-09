import math
import logging

logger = logging.getLogger(__name__)

class Calculator():
    """
    Class containing basic mathematical operations:

    * Addition                      calculator.add(number)
    * Subtraction                   calculator.subtract(number)
    * Division                      calculator.divide(number)
    * Multiplication                calculator.multiply(number)
    * nth root of a number          calculator.n_root(n)
    * Reset                         calculator.reset()
    * Show memory value             calculator.memory()
    """

    def __init__(self, value: float = 0, value2: float = 0):
        self.logger = logging.getLogger(self.__class__.__name__)
        self.value = value
        self.value2 = value2
        self.memory = 0
        self.err = ('Entered value must be float or integer. '
        'Check your input and try again')
        self.logger.debug('{} called with : {} + {}'.format(self.__class__.__name__, self.value, self.value2))
        # "{0}.{1}".format(self.__class__.__module__, self.__class__.__name__)

    # def __getattribute__(self, __name: str) -> Any:
    #     pass

    # def __setattr__(self, __name: str, __value: Any) -> None:
    #     pass

    # @property
    # def value(self):
    #     return self.__value

    # @value.setter
    # def value(self, val):
    #     self.__value = val

    # @value.deleter
    # def value(self):
    #     del self.__value

    def memory(self) -> float:
        self.logger.debug('entry: {}'.format(self.value))
        """Memory value"""
        return self._memory

    def add(self, x: float = 0, y: float = 0) -> float:
        """This function adds two numbers"""
        self.value = x
        self.value2 = y
        self.logger.debug('entry: {} {} '.format(self.value,self.value2))

        if self.value == 0:
            try:
                self.memory += float(self.value)
                return (self.memory)
            except:
                print(self.err)

        return (self.value + self.value2)

    def multiply(self, x: float = 0, y: float = 0) -> float:
        """This function multiplies two numbers"""

        self.value = x
        self.value2 = y
        self.logger.debug('entry: {} {} '.format(self.value,self.value2))

        if self.value == 0:
            try:
                self.memory *= float(self.value)
                return (self.memory)
            except:
                print(self.err)

        return (self.value * self.value2)

    def divide(self, x: float = 0, y: float = 0) -> float:
        """This function divides two numbers"""

        self.value = x
        self.value2 = y
        self.logger.debug('entry: {} {} '.format(self.value,self.value2))

        if self.value2 == 0:
            self.logger.error('Null value is given for division: {}'.format(self.value2))
            raise ValueError("You can t divide by zero!")
        else:
            return round(self.value / self.value2)

    def substract(self, x: float = 0, y: float = 0) -> float:
        """This function subtracts two numbers"""
        self.value = x
        self.value2 = y
        self.logger.debug('entry: {} {} '.format(self.value,self.value2))
        return (self.value - self.value2)

    def modulo(self, x: float = 0, y: float = 0) -> float:
        """This function subtracts two numbers"""
        self.value = x
        self.value2 = y
        self.logger.debug('entry: {} {} '.format(self.value,self.value2))
        return (self.value % self.value2)

    def pow(self, x: float = 0) -> float:
        self.value = x
        self.logger.debug('entry: {}'.format(self.value))
        return self.value ** self.value

    def sqrt(self, x: float = 0) -> float:
        self.value = x
        self.logger.debug('entry: {}'.format(self.value))
        if self.value < 0:
            self.logger.error('Negative value is given: {}'.format(self.value))
            raise ValueError("negative (n) root is not valid")
        else:
            return round(self.value ** 0.5, 5)

    def reset(self) -> None:
        """Resets memory value to its initial value - 0"""
        self.logger.debug('entry: {}'.format(self.value))
        self.value = 0
