import {describe, expect, test} from "@jest/globals";
import {collect, collectOne, distinct, groupBy, mergeBy, partition, shuffle, zip} from "../src";

describe('array', () => {
    test('collect', () => {
        expect(collect([1, 2, 3, 4, 5], i => i % 2 === 0 ? i.toString() : undefined)).toEqual(['2', '4'])
    })
    test('collectOne', () => {
        expect(collectOne([1, 2, 3, 4, 5], i => i % 2 === 0 ? i.toString() : undefined)).toEqual('2')
    })
    test('distinct', () => {
        expect(distinct([1, 1, 2, 3, 5, 3])).toEqual([1, 2, 3, 5])
    })
    test('partition', () => {
        const results = partition([1, 2, 3, 4, 5], i => i % 2 === 0)
        expect(results).toEqual([[2, 4], [1, 3, 5]])
    })
    test('mergeBy', () => {
        type Item = {key: string, value?: string, item?: string}
        const results = mergeBy(
            [{key: 'a', value: 'a'}, {key: 'b', value: 'b'}] as Item[],
            [{key: 'a', item: 'a'}, {key: 'c', item: 'c'}] as Item[],
            i => i.key,
            (i1, i2) => ({...i1, ...i2})
        )
        expect(results).toEqual([
            {key: 'a', value: 'a', item: 'a'},
            {key: 'b', value: 'b'},
            {key: 'c', item: 'c'}
        ])
    })
    test('groupBy', () => {
        expect(groupBy([1, 2, 3], i => i % 2)).toEqual({0: [2], 1: [1, 3]})
    })
    test('shuffle', () => {
        // use long array to reduce the probability to have the same one after shuffle ^^
        const array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
        const shuffled = shuffle(array)
        expect(shuffled).not.toEqual(array)
        expect(shuffled.sort()).toEqual(array.sort())
    })
    test('zip', () => {
        expect(zip([1, 2, 3], ['a', 'b', 'c'])).toEqual([[1, 'a'], [2, 'b'], [3, 'c']])
        expect(zip([1, 2], ['a', 'b', 'c'])).toEqual([[1, 'a'], [2, 'b']])
        expect(zip([1, 2, 3], ['a', 'b'])).toEqual([[1, 'a'], [2, 'b']])
    })
})
